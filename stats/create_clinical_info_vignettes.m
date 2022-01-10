path = 'C:\Users\ozala\Documents\PythonWork\FaceNet\results\Survey\Clinical-Information\';
outpath = [path, 'clin_info_images\']

I = imread([path, 'ClinicalInfoSURVEY.jpg'])
load('clinical_info.mat');

text_str = cell(10,1);
for ii = 2:101
   disp(CancerType(ii))
   text_str{1} = ['Primary Cancer: ', char(CancerType(ii))];
   text_str{2} = ['Age at Treatment: ' num2str(chronologicage(ii),'%0.1f'), ' yrs'];
   text_str{3} = ['Performance Status (ECOG): ' num2str(ECOG(ii), '%d')];
   text_str{4} = ['Metastases: ' char(Mets(ii))];
   text_str{5} = ['ER Visits: ' num2str(ERAdmits(ii),'%d')];
   text_str{6} = ['Hospital Admissions: ' num2str(HospitalAdmits(ii),'%d')];
   text_str{7} = ['Prior Paliative Chemo Courses: ' num2str(PriorPalChemo(ii),'%d')];
   text_str{8} = ['Prior Radiotherapy Courses: ' num2str(PriorPalRTanywhere(ii),'%d')];
   text_str{9} = ['Time to 1st Metastasis: ' num2str(Timeto1stmetastasis(ii),'%0.1f'), ' months'];
   text_str{10} = ['Time to Radiotherapy Consult: ' num2str(Timetoradiotherapyconsult(ii),'%0.1f'), ' months'];

    disp(text_str{1})
    disp(text_str{2})
    disp(text_str{3})
    disp(text_str{4})
    disp(text_str{5})
    disp(text_str{6})
    disp(text_str{7})
    disp(text_str{8})
    disp(text_str{9})
    disp(text_str{10})
    position = [50 100; 50 140; 50 180; 50 220; 50 260; ...
                50 300; 50 340; 50 380; 50 420; 50 460;];
    box_color = {'white'};

    RGB = insertText(I,position,text_str,'FontSize',18,'Font','LucidaSansDemiBold',...
        'BoxColor',box_color,'BoxOpacity',0.4,'TextColor','black');
    
    filename = [outpath, 'clininfo_', photo_id{ii}, '.jpg'];
    
    imwrite(RGB,filename,'jpeg');

    %imshow(RGB)

end